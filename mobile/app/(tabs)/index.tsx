import * as React from 'react';
import { Image } from 'expo-image';
import { Button, StyleSheet } from 'react-native';

import ParallaxScrollView from '@/components/parallax-scroll-view';
import { ThemedView } from '@/components/themed-view';
import DevLauncherModule from '@/modules/dev-launcher/src/DevLauncherModule';

export default function HomeScreen() {


  return (
    <ParallaxScrollView
      headerBackgroundColor={{ light: '#FDBB00', dark: '#1D3D47' }}
      headerImage={
        <Image
          source={require('@/assets/images/partial-react-logo.png')}
          style={styles.reactLogo}
        />
      }>
     
      <ThemedView style={styles.stepContainer}>
        <Button title="Go to Details" onPress={async () => {
         await DevLauncherModule.loadAppFromBundleUrl("https://nnyue.vm.freestyle.sh/node_modules/expo-router/entry.bundle?platform=ios&dev=true&hot=false&lazy=true&transform.engine=hermes&transform.bytecode=1&transform.routerRoot=app&unstable_transformProfile=hermes-stable")
        }} />
      </ThemedView>
  
</ParallaxScrollView>
  );
}

const styles = StyleSheet.create({
  titleContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  stepContainer: {
    gap: 8,
    marginBottom: 8,
  },
  reactLogo: {
    height: 178,
    width: 290,
    bottom: 0,
    left: 0,
    position: 'absolute',
  },
});
