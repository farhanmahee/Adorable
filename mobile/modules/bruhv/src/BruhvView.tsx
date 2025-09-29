import { requireNativeView } from 'expo';
import * as React from 'react';

import { BruhvViewProps } from './Bruhv.types';

const NativeView: React.ComponentType<BruhvViewProps> =
  requireNativeView('Bruhv');

export default function BruhvView(props: BruhvViewProps) {
  return <NativeView {...props} />;
}
