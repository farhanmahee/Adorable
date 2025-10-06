import * as React from 'react';
import { StyleSheet, View, ActivityIndicator } from 'react-native';
import { Stack, useRouter } from 'expo-router';
import { ReactBundleView } from '@/modules/dev-launcher';
import { Host, Button } from '@expo/ui/swift-ui';

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
        <Host style={styles.backButtonHost}>
          <Button
            systemImage="chevron.left"
            variant="glass"
            onPress={() => router.back()}
            >
          </Button>
        </Host>
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
  backButtonHost: {
    position: 'absolute',
    top: 50,
    left: 24,
    padding: 20,
    zIndex: 1000,
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
