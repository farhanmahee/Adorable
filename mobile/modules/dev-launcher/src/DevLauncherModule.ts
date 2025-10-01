import { NativeModule, requireNativeModule } from 'expo';

import { DevLauncherModuleEvents } from './DevLauncher.types';

declare class DevLauncherModule extends NativeModule<DevLauncherModuleEvents> {
  PI: number;
  hello(): string;
  setValueAsync(value: string): Promise<void>;
}

// This call loads the native module object from the JSI.
export default requireNativeModule<DevLauncherModule>('DevLauncher');
