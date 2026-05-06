const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

const COMMISSION_RATE = 0.15;

// ── Trigger: intervention créée → notifier le prestataire ─────────────────────
exports.onInterventionCreated = functions
  .region('europe-west1')
  .firestore.document('interventions/{interventionId}')
  .onCreate(async (snap, ctx) => {
    const data = snap.data();
    if (!data.provider_id) return;

    const providerDoc = await db
      .collection('providers')
      .doc(data.provider_id)
      .get();

    if (!providerDoc.exists) return;
    const fcmToken = providerDoc.data().fcm_token;
    if (!fcmToken) return;

    await messaging.send({
      token: fcmToken,
      notification: {
        title: '🚨 Nouvelle demande d\'intervention !',
        body: `${data.service_type_name} — ${_formatFcfa(data.total_price)} — ${data.user_address ?? 'Position inconnue'}`,
      },
      data: {
        type: 'new_intervention',
        intervention_id: ctx.params.interventionId,
      },
      android: { priority: 'high' },
      apns: { payload: { aps: { sound: 'default', badge: 1 } } },
    });
  });

// ── Trigger: statut changé → notifier l'utilisateur ──────────────────────────
exports.onInterventionStatusChanged = functions
  .region('europe-west1')
  .firestore.document('interventions/{interventionId}')
  .onUpdate(async (change, ctx) => {
    const before = change.before.data();
    const after = change.after.data();

    if (before.status === after.status) return;

    const userDoc = await db
      .collection('users')
      .doc(after.user_id)
      .get();

    if (!userDoc.exists) return;
    const fcmToken = userDoc.data().fcm_token;
    if (!fcmToken) return;

    const { title, body } = _statusNotification(
      after.status,
      after.provider_name,
      after.service_type_name
    );

    await messaging.send({
      token: fcmToken,
      notification: { title, body },
      data: {
        type: 'intervention_update',
        intervention_id: ctx.params.interventionId,
        status: after.status,
      },
    });

    // Créer une transaction quand intervention terminée
    if (after.status === 'completed') {
      await _createTransaction(ctx.params.interventionId, after);
    }
  });

// ── Trigger: intervention complétée → créer transaction + mettre à jour stats ─
async function _createTransaction(interventionId, data) {
  const commission = data.total_price * COMMISSION_RATE;
  const providerNet = data.total_price - commission;

  const batch = db.batch();

  // Transaction record
  const txRef = db.collection('transactions').doc();
  batch.set(txRef, {
    intervention_id: interventionId,
    user_id: data.user_id,
    provider_id: data.provider_id,
    gross_amount: data.total_price,
    commission,
    net_amount: providerNet,
    payment_method: data.payment_method,
    status: 'completed',
    created_at: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Update provider earnings & intervention count
  if (data.provider_id) {
    const providerRef = db.collection('providers').doc(data.provider_id);
    batch.update(providerRef, {
      total_earnings: admin.firestore.FieldValue.increment(providerNet),
      total_interventions: admin.firestore.FieldValue.increment(1),
    });
  }

  // Update user intervention count
  const userRef = db.collection('users').doc(data.user_id);
  batch.update(userRef, {
    total_interventions: admin.firestore.FieldValue.increment(1),
  });

  await batch.commit();
}

// ── Trigger: notation soumise → recalculer la moyenne ──────────────────────────
exports.onReviewCreated = functions
  .region('europe-west1')
  .firestore.document('reviews/{reviewId}')
  .onCreate(async (snap) => {
    const review = snap.data();
    const { to_user_id, from_role, rating } = review;

    const collection =
      from_role === 'user' ? 'providers' : 'users';

    const reviews = await db
      .collection('reviews')
      .where('to_user_id', '==', to_user_id)
      .get();

    const ratings = reviews.docs.map((d) => d.data().rating);
    const avg = ratings.reduce((a, b) => a + b, 0) / ratings.length;

    await db.collection(collection).doc(to_user_id).update({
      rating: parseFloat(avg.toFixed(2)),
    });
  });

// ── HTTP: vérifier le statut de paiement Mobile Money ─────────────────────────
exports.checkPaymentStatus = functions
  .region('europe-west1')
  .https.onCall(async (data, ctx) => {
    if (!ctx.auth) throw new functions.https.HttpsError('unauthenticated', 'Non authentifié');

    const { reference, provider } = data;
    // TODO: Intégrer l'API Orange Money / Wave ici
    // Pour l'instant, on simule une réponse
    return { status: 'pending', reference };
  });

// ── HTTP: admin — suspendre un compte ─────────────────────────────────────────
exports.suspendAccount = functions
  .region('europe-west1')
  .https.onCall(async (data, ctx) => {
    if (!ctx.auth) throw new functions.https.HttpsError('unauthenticated', 'Non authentifié');

    const callerDoc = await db.collection('admins').doc(ctx.auth.uid).get();
    if (!callerDoc.exists) {
      throw new functions.https.HttpsError('permission-denied', 'Accès refusé');
    }

    const { uid, role, reason } = data;
    const col = role === 'provider' ? 'providers' : 'users';
    await db.collection(col).doc(uid).update({
      is_blocked: true,
      block_reason: reason,
      blocked_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Disable Firebase Auth account
    await admin.auth().updateUser(uid, { disabled: true });

    return { success: true };
  });

// ── Helpers ────────────────────────────────────────────────────────────────────
function _formatFcfa(amount) {
  return `${Math.round(amount).toLocaleString('fr-FR')} FCFA`;
}

function _statusNotification(status, providerName, serviceName) {
  switch (status) {
    case 'accepted':
      return {
        title: '✅ Demande acceptée !',
        body: `${providerName ?? 'Un prestataire'} est en route pour votre ${serviceName}.`,
      };
    case 'in_progress':
      return {
        title: '🔧 Intervention en cours',
        body: `${providerName ?? 'Le prestataire'} a démarré l\'intervention.`,
      };
    case 'completed':
      return {
        title: '🎉 Intervention terminée !',
        body: 'Pensez à noter votre prestataire.',
      };
    case 'cancelled':
      return {
        title: '❌ Intervention annulée',
        body: 'Votre demande a été annulée.',
      };
    default:
      return { title: 'Auto-SOS', body: 'Mise à jour de votre intervention.' };
  }
}
