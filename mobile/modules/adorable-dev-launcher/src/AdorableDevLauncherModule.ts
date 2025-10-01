import { NativeModule, requireNativeModule } from 'expo';

import { AdorableDevLauncherModuleEvents } from './AdorableDevLauncher.types';

declare class AdorableDevLauncherModule extends NativeModule<AdorableDevLauncherModuleEvents> {
  PI: number;
  hello(): string;
  setValueAsync(value: string): Promise<void>;


  // New: load from an explicit Metro bundle URL (preserves host/path)
  loadAppWithURL(url: string): Promise<void>;
}

// This call loads the native module object from the JSI.
export default requireNativeModule<AdorableDevLauncherModule>('AdorableDevLauncher');
