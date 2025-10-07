import * as React from 'react';
import { StyleSheet, View } from 'react-native';
import { Stack, useRouter, useLocalSearchParams, usePathname } from 'expo-router';
import { SafeAreaView } from 'react-native-safe-area-context';
import { ThemedView } from '@/components/themed-view';
import { ThemedText } from '@/components/themed-text';
import { Host, Button } from '@expo/ui/swift-ui';

export default function TestScreen() {
  const router = useRouter();
  const { id } = useLocalSearchParams<{ id: string }>();
  const pathname = usePathname();

  return (
    <>
      <Stack.Screen options={{ headerShown: false }} />
      <SafeAreaView style={styles.container}>
        <ThemedView style={styles.content}>
          <Host style={styles.backButtonHost}>
            <Button
              systemImage="chevron.left"
              variant="glass"
              onPress={() => router.push('/')}
            >
            </Button>
          </Host>
          <ThemedText style={styles.text}>Current Path: {pathname}</ThemedText>
          <ThemedText style={styles.text}>ID: {id}</ThemedText>
        </ThemedView>
      </SafeAreaView>
    </>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  content: {
    flex: 1,
    padding: 20,
  },
  backButtonHost: {
    position: 'absolute',
    top: 50,
    left: 24,
    padding: 20,
    zIndex: 1000,
  },
  text: {
    fontSize: 18,
    marginTop: 100,
  },
});
