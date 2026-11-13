// entry/src/main/ets/viewmodel/NavStackModel.ets
import { IDOBleDeviceModel, IDOTransType } from 'protocol_channel';
import { FunctionInfo } from './FunctionListViewModel';

/**
 * @desc 定义导航参数的接口，明确所有可能的属性及其类型。 / Interface defining the navigation parameters, with all possible fields and their types.
 * 所有属性都设为可选(?)，因为并非每次导航都会用到全部参数。
 * All fields are optional (?) because not every navigation uses all of them.
 */
export interface NavParam {
  navTitle?: string | Resource;
  device?: IDOBleDeviceModel;
  autoConnect?:boolean,
  functionName?: string;
  initialParams?: string;
  funcInfo?: FunctionInfo;
  transType?: IDOTransType;
}

/**
 * @desc 定义导航栈中每一个路径节点的数据结构。 / Data structure of each path node in the navigation stack.
 */
export class NavStackModel {
  // 目标的唯一名称
  // Unique name of the target
  name: string;
  // 传递给目标视图的参数，类型为我们明确定义的 NavParam 接口
  // Parameters passed to the target view, typed as our explicitly defined NavParam interface
  param?: NavParam;

  constructor(name: string, param?: NavParam) {
    this.name = name;
    this.param = param;
  }
}