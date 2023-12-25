import { Options } from './Options';

export class RecursionDepth {
  constructor(private options: Options, private fileRecursionDepth = 0, private packageRecursionDepth = 0) {}

  public nextPackage() {
    return new RecursionDepth(this.options, this.fileRecursionDepth, this.packageRecursionDepth + 1);
  }

  public nextFile() {
    return new RecursionDepth(this.options, this.fileRecursionDepth + 1, this.packageRecursionDepth);
  }

  public same() {
    return new RecursionDepth(this.options, this.fileRecursionDepth, this.packageRecursionDepth);
  }

  public shouldStop() {
    return (
      (this.options.fileRecursionDepth > 0 && this.fileRecursionDepth >= this.options.fileRecursionDepth) ||
      (this.options.packageRecursionDepth > 0 && this.packageRecursionDepth >= this.options.packageRecursionDepth)
    );
  }
}
