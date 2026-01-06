// entry/src/main/ets/pages/GetFunctionListPage.ets
import { CommonListItem } from '../components/CommonListItem';
import { getFunctionList, FunctionInfo } from '../viewmodel/FunctionListViewModel';
import { PAGE_FUNCTION_TEST, PAGE_GET_FUNCTION_LIST } from '../utils/Routers';
import { ApiEvtType, IDOBleDeviceModel } from 'protocol_channel';
import { NavParam, NavStackModel } from '../viewmodel/NavStackModel';

@Builder
export function GetFunctionListPageBuilder(name: string, navInfo: NavStackModel) {
  GetFunctionListPage({ device: navInfo.param?.device })
}

@ComponentV2
struct GetFunctionListPage {
  @Param device: IDOBleDeviceModel | null = null;
  private pageInfos: NavPathStack | null = null;
  private functions: FunctionInfo[] = getFunctionList();

  onItemClick(func: FunctionInfo) {
    if (!this.pageInfos) {
      return;
    }
    let navInfo = new NavStackModel(PAGE_GET_FUNCTION_LIST, {
      functionName: func.name,
      initialParams: '{}',
      funcInfo: func,
      device: this.device!
    });
    this.pageInfos.pushPathByName(PAGE_FUNCTION_TEST, navInfo);
  }

  build() {
    NavDestination() {
      List({ space: 1 }) {
        ForEach(this.functions, (item: FunctionInfo) => {
          CommonListItem({ title: item.name, subtitle: item.description })
            .onClick(() => this.onItemClick(item))
        })
      }
      .width('100%').backgroundColor($r('app.color.page_bg')).padding({ top: 12 })
    }.onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    }).title($r('app.string.get_function'))
  }
}