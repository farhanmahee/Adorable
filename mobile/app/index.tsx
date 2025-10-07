import * as React from "react";
import { Button, StyleSheet, FlatList } from "react-native";
import { useRouter } from "expo-router";
import { SafeAreaView } from "react-native-safe-area-context";

import { ThemedView } from "@/components/themed-view";
import DevLauncherModule from "@/modules/dev-launcher/src/DevLauncherModule";
import { ThemedText } from "@/components/themed-text";
import { listApps, type App } from "../lib/stub";

export default function HomeScreen() {
  const router = useRouter();
  const [isMetroRunning, setIsMetroRunning] = React.useState<boolean | null>(
    null
  );
  const apps = listApps();

  React.useEffect(() => {
    async function checkMetro() {
      const isRunning = await DevLauncherModule.detectMetroRunning();
      setIsMetroRunning(isRunning);
    }
    checkMetro();
  }, []);

  const renderApp = ({ item }: { item: App }) => (
    <ThemedView style={styles.appItem}>
      <Button
        title={item.name}
        onPress={() => {
          router.push(`/app/${item.id}`);
        }}
      />
    </ThemedView>
  );

  return (
    <ThemedView style={styles.content}>
      <SafeAreaView style={styles.container}>
        <FlatList
          data={apps}
          renderItem={renderApp}
          keyExtractor={(item) => item.id}
        />
        <ThemedText>
          Is Metro Running:{" "}
          {isMetroRunning == null ? "Unknown" : isMetroRunning ? "Yes" : "No"}
        </ThemedText>
        <ThemedText>
          Is RCTDev Enabled:{" "}
          {DevLauncherModule.isRCTDevEnabled() ? "Yes" : "No"}
        </ThemedText>
      </SafeAreaView>
    </ThemedView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  content: {
    flex: 1,
  },
  appItem: {
    padding: 10,
    flex: 1,
    padding: 20,
    gap: 16,
  },
});
