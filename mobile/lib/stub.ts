export interface App {
  id: string;
  name: string;
  bundleUrl: string;
}

const apps: App[] = [
  {
    id: "1",
    name: "App One",
    bundleUrl: "https://nnyue.vm.freestyle.sh/node_modules/expo-router/entry.bundle?platform=ios&dev=true&hot=false&lazy=true&transform.engine=hermes&transform.bytecode=1&transform.routerRoot=app&unstable_transformProfile=hermes-stable",
  },
  {
    id: "2",
    name: "App Two",
    bundleUrl: "https://nnyue.vm.freestyle.sh/node_modules/expo-router/entry.bundle?platform=ios&dev=true&hot=false&lazy=true&transform.engine=hermes&transform.bytecode=1&transform.routerRoot=app&unstable_transformProfile=hermes-stable",
  },
  {
    id: "3",
    name: "App Three",
    bundleUrl: "https://nnyue.vm.freestyle.sh/node_modules/expo-router/entry.bundle?platform=ios&dev=true&hot=false&lazy=true&transform.engine=hermes&transform.bytecode=1&transform.routerRoot=app&unstable_transformProfile=hermes-stable",
  },
];

export function listApps(): App[] {
  return apps;
}

export function getApp(id: string): App | undefined {
  return apps.find((app) => app.id === id);
}
