import { requireNativeView } from 'expo';
import * as React from 'react';

import { AdorableDevLauncherViewProps } from './AdorableDevLauncher.types';

const NativeView: React.ComponentType<AdorableDevLauncherViewProps> =
  requireNativeView('AdorableDevLauncher');

export default function AdorableDevLauncherView(props: AdorableDevLauncherViewProps) {
  return <NativeView {...props} />;
}
