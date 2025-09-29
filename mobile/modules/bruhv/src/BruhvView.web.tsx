import * as React from 'react';

import { BruhvViewProps } from './Bruhv.types';

export default function BruhvView(props: BruhvViewProps) {
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
