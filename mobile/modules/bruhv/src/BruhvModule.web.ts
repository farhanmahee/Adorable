import { registerWebModule, NativeModule } from 'expo';

import { ChangeEventPayload } from './Bruhv.types';

type BruhvModuleEvents = {
  onChange: (params: ChangeEventPayload) => void;
}

class BruhvModule extends NativeModule<BruhvModuleEvents> {
  PI = Math.PI;
  async setValueAsync(value: string): Promise<void> {
    this.emit('onChange', { value });
  }
  hello() {
    return 'Hello world! 👋';
  }
};

export default registerWebModule(BruhvModule, 'BruhvModule');
