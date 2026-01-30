type Handler<Args extends unknown[]> = (...args: Args) => void;

export class TypedEmitter<Events extends Record<string, unknown[]>> {
  private handlers = new Map<keyof Events, Set<Handler<unknown[]>>>();

  on<K extends keyof Events>(event: K, handler: Handler<Events[K]>): void {
    const set = this.handlers.get(event) ?? new Set<Handler<unknown[]>>();
    set.add(handler as Handler<unknown[]>);
    this.handlers.set(event, set);
  }

  off<K extends keyof Events>(event: K, handler: Handler<Events[K]>): void {
    const set = this.handlers.get(event);
    if (!set) {
      return;
    }
    set.delete(handler as Handler<unknown[]>);
    if (set.size === 0) {
      this.handlers.delete(event);
    }
  }

  emit<K extends keyof Events>(event: K, ...args: Events[K]): void {
    const set = this.handlers.get(event);
    if (!set) {
      return;
    }
    for (const handler of set) {
      (handler as Handler<Events[K]>)(...args);
    }
  }
}
