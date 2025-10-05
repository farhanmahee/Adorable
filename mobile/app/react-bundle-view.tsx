import * as React from 'react';
import { StyleSheet, TouchableOpacity, View, ActivityIndicator } from 'react-native';
import { Stack, useRouter } from 'expo-router';
import { ReactBundleView } from '@/modules/dev-launcher';
import { Ionicons } from '@expo/vector-icons';

const LoadingView = React.forwardRef<View>((props, ref) => (
  <View ref={ref} style={styles.loadingContainer} {...props}>
    <ActivityIndicator size="large" color="#007AFF" />
  </View>
));
LoadingView.displayName = 'LoadingView';

export default function ReactBundleViewScreen() {
  const router = useRouter();

  return (
    <>
      <Stack.Screen options={{ headerShown: false }} />
      <View style={styles.container}>
        <TouchableOpacity
          onPress={() => router.back()}
          style={styles.backButton}
        >
          <Ionicons name="arrow-back" size={24} color="#007AFF" />
        </TouchableOpacity>
        <ReactBundleView
          url="https://nnyue.vm.freestyle.sh/node_modules/expo-router/entry.bundle?platform=ios&dev=true&hot=false&lazy=true&transform.engine=hermes&transform.bytecode=1&transform.routerRoot=app&unstable_transformProfile=hermes-stable"
          onLoad={(event) => console.log('Bundle loaded:', event.nativeEvent.url)}
          style={styles.bundleView}
        />
      </View>
    </>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  backButton: {
    position: 'absolute',
    top: 50,
    left: 16,
    zIndex: 1000,
    padding: 8,
  },
  bundleView: {
    flex: 1,
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'rgba(255, 255, 255, 0.95)',
  },
});
