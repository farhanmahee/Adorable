import { NativeModule, requireNativeModule } from 'expo';

import { DevLauncherModuleEvents } from './DevLauncher.types';

declare class DevLauncherModule extends NativeModule<DevLauncherModuleEvents> {
  loadAppFromBundleUrl(url: string): Promise<void>;
}

export default requireNativeModule<DevLauncherModule>('DevLauncher');
