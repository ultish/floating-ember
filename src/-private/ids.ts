let seq = 0;

export function nextId(prefix = 'floating'): string {
  seq += 1;
  return `${prefix}-${seq}`;
}
