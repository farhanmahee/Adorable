import { NativeModule, requireNativeModule } from 'expo';

import { BruhvModuleEvents } from './Bruhv.types';

declare class BruhvModule extends NativeModule<BruhvModuleEvents> {
  PI: number;
  hello(): string;
  setValueAsync(value: string): Promise<void>;
}

// This call loads the native module object from the JSI.
export default requireNativeModule<BruhvModule>('Bruhv');
