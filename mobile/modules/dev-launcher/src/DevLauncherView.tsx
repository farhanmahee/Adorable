import { requireNativeView } from 'expo';
import * as React from 'react';

import { DevLauncherViewProps } from './DevLauncher.types';

const NativeView: React.ComponentType<DevLauncherViewProps> =
  requireNativeView('DevLauncher');

export default function DevLauncherView(props: DevLauncherViewProps) {
  return <NativeView {...props} />;
}
