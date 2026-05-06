export interface Profile {
  id: string;
  username: string;
  email: string;
  avatar_url?: string;
  created_at: string;
}

export interface Folder {
  id: string;
  user_id: string;
  name: string;
  color: string;
  icon: string;
  notes_count?: number;
  created_at: string;
}

export interface Note {
  id: string;
  user_id: string;
  folder_id?: string | null;
  title: string;
  content: string;
  is_pinned: boolean;
  created_at: string;
  updated_at: string;
  folder?: Folder;
}

export type RootStackParamList = {
  Auth: undefined;
  Main: undefined;
};

export type AuthStackParamList = {
  Login: undefined;
  Register: undefined;
};

export type MainTabParamList = {
  Home: undefined;
  Folders: undefined;
  Profile: undefined;
};

export type HomeStackParamList = {
  NotesList: undefined;
  NoteDetail: { noteId?: string; folderId?: string };
};

export type FoldersStackParamList = {
  FoldersList: undefined;
  FolderNotes: { folder: Folder };
  NoteDetail: { noteId?: string; folderId?: string };
};
