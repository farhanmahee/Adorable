import * as React from 'react';

import { DevLauncherViewProps } from './DevLauncher.types';

export default function DevLauncherView(props: DevLauncherViewProps) {
  return (
    <div>
      <iframe
        style={{ flex: 1 }}
        src={props.url}
        onLoad={() => props.onLoad({ nativeEvent: { url: props.url } })}
      />
    </div>
  );
}
