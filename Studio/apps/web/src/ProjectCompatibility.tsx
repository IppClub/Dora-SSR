import {useMemo} from 'react';
import type {ProjectSnapshot} from '@dora-studio/contracts';
import {inspectProjectCompatibility} from './project-compatibility';
import './project-compatibility.css';
export function ProjectCompatibility({snapshot}:{snapshot:ProjectSnapshot}) {
  const report=useMemo(()=>inspectProjectCompatibility(snapshot),[snapshot]);
  return <details className="project-compatibility"><summary>兼容检查 · {report.warnings.length?`${report.warnings.length} 项待确认`:'尚未验证运行'}</summary>
    <p>入口：{snapshot.entry}。{report.entrySupported?'当前编译链支持该入口类型，但不代表代码已编译或运行成功。':'该入口类型暂不能在当前编译链构建。'}</p>
    {report.declaredEngine&&<p>原包声明引擎版本：{report.declaredEngine}。此声明尚未与实际运行环境核对。</p>}
    {report.warnings.length>0&&<ul>{report.warnings.map(warning=><li key={warning}>{warning}</li>)}</ul>}
    <p>这是当前文件的静态检查，不会自动修改或执行项目。请结合编译诊断与实际试玩确认；当前工作区仍可保存和导出。</p>
  </details>;
}
