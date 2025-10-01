import { registerWebModule, NativeModule } from 'expo';

import { ChangeEventPayload } from './DevLauncher.types';

type DevLauncherModuleEvents = {
  onChange: (params: ChangeEventPayload) => void;
}

class DevLauncherModule extends NativeModule<DevLauncherModuleEvents> {
  PI = Math.PI;
  async setValueAsync(value: string): Promise<void> {
    this.emit('onChange', { value });
  }
  hello() {
    return 'Hello world! 👋';
  }
};

export default registerWebModule(DevLauncherModule, 'DevLauncherModule');
