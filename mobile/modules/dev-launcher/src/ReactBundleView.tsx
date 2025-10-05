import { ViewProps } from 'react-native';
import { requireNativeViewManager } from 'expo-modules-core';
import * as React from 'react';

export type OnLoadEvent = {
  url: string;
};

export type ReactBundleViewProps = {
  url: string;
  onLoad?: (event: { nativeEvent: OnLoadEvent }) => void;
} & ViewProps;

const NativeView: React.ComponentType<ReactBundleViewProps> =
  requireNativeViewManager('DevLauncher');

export default function ReactBundleView(props: ReactBundleViewProps) {
  return <NativeView {...props} />;
}
