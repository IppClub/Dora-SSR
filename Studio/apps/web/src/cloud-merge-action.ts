import {createContext} from 'react';
import type {previewCloudMerge} from './cloud-merge-preview';
import type {ConflictResolution,FileChoice} from './cloud-merge-resolution';
export type MergeAction=(preview:Awaited<ReturnType<typeof previewCloudMerge>>,choices:ReadonlyMap<string,ConflictResolution>,entry:FileChoice|undefined)=>Promise<void>;
export const CloudMergeAction=createContext<MergeAction|null>(null);
