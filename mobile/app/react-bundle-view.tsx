import * as React from 'react';
import { StyleSheet } from 'react-native';
import { Stack } from 'expo-router';
import { ReactBundleView } from '@/modules/dev-launcher';

export default function ReactBundleViewScreen() {
  return (
    <>
      <Stack.Screen options={{ headerShown: false, }} />
      <ReactBundleView
        url="https://nnyue.vm.freestyle.sh/node_modules/expo-router/entry.bundle?platform=ios&dev=true&hot=false&lazy=true&transform.engine=hermes&transform.bytecode=1&transform.routerRoot=app&unstable_transformProfile=hermes-stable"
        onLoad={(event) => console.log('Bundle loaded:', event.nativeEvent.url)}
        style={styles.container}
      />
    </>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
});
