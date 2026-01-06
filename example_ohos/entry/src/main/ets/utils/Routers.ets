// // 导入所有页面的构建器函数
// import { FunctionPageBuilder } from '../pages/FunctionList';
// import { GetFunctionListPageBuilder } from '../pages/GetFunctionList';
// import { SetFunctionListPageBuilder } from '../pages/SetFunctionList';
// import { SyncDataPageBuilder } from '../pages/SyncData';
// import { TransferFilePageBuilder } from '../pages/TransferFile';
// import { FirmwareUpgradePageBuilder } from '../pages/FirmwareUpgrade';
// import { MessageNoticePageBuilder } from '../pages/MessageNotice';
// import { SportPageBuilder } from '../pages/Sport';
// import { FunctionTestPageBuilder } from '../pages/FunctionTest';
// import { EpoUpgradePageBuilder } from '../pages/EpoUpgrade';
// import { NavPathModel } from '../viewmodel/NavStackModel';

/**
 * 主功能列表页
 */
export const PAGE_FUNCTION_LIST = 'functionListPage';
export const PAGE_GET_FUNCTION_LIST = 'getFunctionListPage';
export const PAGE_SET_FUNCTION_LIST = 'setFunctionListPage';
export const PAGE_SYNC_DATA = 'syncDataPage';
export const PAGE_TRANSFER_FILE = 'transferFilePage';
// export const PAGE_FIRMWARE_UPGRADE = 'firmwareUpgradePage';
export const PAGE_MESSAGE_NOTICE = 'messageNoticePage';
export const PAGE_MESSAGE_NOTICE_S = 'staticMessageNoticePage';
export const PAGE_SPORT = 'sportPage';
export const PAGE_FUNCTION_TEST = 'functionTestPage';
export const PAGE_EPO_UPGRADE = 'epoUpgradePage';
export const PAGE_TRANSFER_FILE_DETAIL = 'transferFileDetail';
export const PAGE_WATCH_FACE_DETAIL = 'watchFace';

// // 创建一个路由构建器的映射表
// export const ROUTER_BUILDER_MAP: Record<string, (name: string, navInfo: NavPathModel) => void> = {
//   PAGE_FUNCTION_LIST: FunctionPageBuilder,
//   PAGE_GET_FUNCTION_LIST: GetFunctionListPageBuilder,
//   PAGE_SET_FUNCTION_LIST: SetFunctionListPageBuilder,
//   PAGE_SYNC_DATA: SyncDataPageBuilder,
//   PAGE_TRANSFER_FILE: TransferFilePageBuilder,
//   PAGE_FIRMWARE_UPGRADE: FirmwareUpgradePageBuilder,
//   PAGE_MESSAGE_NOTICE: MessageNoticePageBuilder,
//   PAGE_SPORT: SportPageBuilder,
//   PAGE_FUNCTION_TEST: FunctionTestPageBuilder,
//   PAGE_EPO_UPGRADE: EpoUpgradePageBuilder
// };