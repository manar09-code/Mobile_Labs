import { useCallback, useEffect, useState } from 'react';
import {
  ActivityIndicator,
  Alert,
  FlatList,
  Pressable,
  RefreshControl,
  StyleSheet,
  Text,
  View,
} from 'react-native';

import { EmptyState } from '../components/EmptyState';
import { NoteInputModal } from '../components/NoteInputModal';
import { NoteItem } from '../components/NoteItem';
import { useAuth } from '../context/AuthContext';
import { errorMessage } from '../lib/errors';
import { createNote, deleteNote, listNotes, updateNote } from '../services/notes';
import type { Note, NoteDraft } from '../types';

type EditingNote = Note | 'new' | null;

export default function NotesScreen() {
  const user = useAuth().user;
  const userId = user?.$id ?? '';

  const [notes, setNotes] = useState<Note[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [actionError, setActionError] = useState<string | null>(null);
  const [editing, setEditing] = useState<EditingNote>(null);

  const requestNotes = useCallback(async () => {
    if (!userId) throw new Error('No authenticated user is available.');
    return listNotes();
  }, [userId]);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      setNotes(await requestNotes());
    } catch (loadError) {
      setError(errorMessage(loadError));
    } finally {
      setLoading(false);
    }
  }, [requestNotes]);

  useEffect(() => {
    let active = true;

    void requestNotes()
      .then((loadedNotes) => {
        if (active) setNotes(loadedNotes);
      })
      .catch((loadError: unknown) => {
        if (active) setError(errorMessage(loadError));
      })
      .finally(() => {
        if (active) setLoading(false);
      });

    return () => {
      active = false;
    };
  }, [requestNotes]);

  const save = async (draft: NoteDraft) => {
    setActionError(null);
    try {
      if (editing === 'new') {
        const created = await createNote(userId, draft);
        setNotes((current) => [created, ...current]);
      } else if (editing) {
        const updated = await updateNote(editing.id, draft);
        setNotes((current) => current.map((note) => (note.id === updated.id ? updated : note)));
      }
      setEditing(null);
    } catch (saveError) {
      setActionError(`Could not save note: ${errorMessage(saveError)}`);
    }
  };

  const remove = (id: string) => {
    const note = notes.find((item) => item.id === id);
    setActionError(null);
    Alert.alert('Delete note', `Delete "${note?.title ?? 'this note'}"?`, [
      { text: 'Cancel', style: 'cancel' },
      {
        text: 'Delete',
        style: 'destructive',
        onPress: () => {
          void deleteNote(id)
            .then(() => setNotes((current) => current.filter((item) => item.id !== id)))
            .catch((deleteError: unknown) => setActionError(
              `Could not delete note: ${errorMessage(deleteError)}`,
            ));
        },
      },
    ]);
  };

  const initialNote = editing && editing !== 'new' ? editing : undefined;

  if (!user) {
    return (
      <View style={styles.loading}>
        <Text>Waiting for your session...</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      {actionError && (
        <View style={styles.errorContainer}>
          <Text style={styles.error}>{actionError}</Text>
          <Pressable onPress={() => setActionError(null)} accessibilityRole="button">
            <Text style={styles.retry}>Dismiss</Text>
          </Pressable>
        </View>
      )}
      {error && (
        <View style={styles.errorContainer}>
          <Text style={styles.error}>{error}</Text>
          <Pressable onPress={() => void load()} accessibilityRole="button">
            <Text style={styles.retry}>Retry</Text>
          </Pressable>
        </View>
      )}
      {loading && notes.length === 0 ? (
        <View style={styles.loading}>
          <ActivityIndicator size="large" color="#208AEF" />
        </View>
      ) : (
        <FlatList
          contentContainerStyle={notes.length === 0 ? styles.emptyList : styles.list}
          data={notes}
          keyExtractor={(note) => note.id}
          renderItem={({ item }) => (
            <NoteItem note={item} onEdit={setEditing} onDelete={remove} />
          )}
          ItemSeparatorComponent={() => <View style={styles.separator} />}
          ListEmptyComponent={!error ? <EmptyState onCreate={() => setEditing('new')} /> : null}
          refreshControl={<RefreshControl refreshing={loading} onRefresh={() => void load()} />}
        />
      )}
      <Pressable
        style={styles.addButton}
        onPress={() => setEditing('new')}
        accessibilityRole="button"
        accessibilityLabel="Create a note">
        <Text style={styles.addButtonText}>+</Text>
      </Pressable>
      <NoteInputModal
        visible={editing !== null}
        initial={initialNote}
        onSave={(draft) => void save(draft)}
        onCancel={() => setEditing(null)}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#fff' },
  loading: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  list: { padding: 16 },
  emptyList: { flexGrow: 1, justifyContent: 'center' },
  separator: { height: 12 },
  errorContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    gap: 12,
    paddingHorizontal: 16,
    paddingVertical: 10,
  },
  error: { color: '#c0392b', flex: 1 },
  retry: { color: '#208AEF', fontWeight: 'bold' },
  addButton: {
    position: 'absolute',
    right: 24,
    bottom: 24,
    width: 56,
    height: 56,
    borderRadius: 28,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#208AEF',
    elevation: 4,
  },
  addButtonText: { color: '#fff', fontSize: 32, lineHeight: 36 },
});
