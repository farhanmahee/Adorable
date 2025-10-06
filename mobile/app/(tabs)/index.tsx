import * as React from 'react';
import { Image } from 'expo-image';
import { Button, StyleSheet } from 'react-native';
import { useRouter } from 'expo-router';

import ParallaxScrollView from '@/components/parallax-scroll-view';
import { ThemedView } from '@/components/themed-view';
import DevLauncherModule from '@/modules/dev-launcher/src/DevLauncherModule';
import { ThemedText } from '@/components/themed-text';

export default function HomeScreen() {
  const router = useRouter();
  const [isMetroRunning, setIsMetroRunning] = React.useState<boolean | null>(null);

  React.useEffect(() => {
    async function checkMetro() {
      const isRunning = await DevLauncherModule.detectMetroRunning();
      setIsMetroRunning(isRunning);
    }
    checkMetro();
  }, []);
  

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
        
        <Button title="Open Via React Native" onPress={() => {
          router.push('/react-bundle-view');
        }} />
        <ThemedText>Is Metro Running: {isMetroRunning == null ? 'Unknown' : isMetroRunning ? 'Yes' : 'No'}</ThemedText>
        <ThemedText>Is RCTDev Enabled: {DevLauncherModule.isRCTDevEnabled() ? 'Yes' : 'No'}</ThemedText>
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
