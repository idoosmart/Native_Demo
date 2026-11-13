// src/main/ets/utils/FilePicker.ets

import { picker } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';

/**
 * 文件选择器的配置选项
 * Configuration options of the file picker
 */
export interface SelectOptions {
  /**
   * 允许的文件后缀名数组，包含点号。
   * Array of allowed file suffixes, including the dot.
   * 例如: ['.jpg', '.png'], ['.pdf'], ['.doc', '.docx']
   * Example: ['.jpg', '.png'], ['.pdf'], ['.doc', '.docx']
   */
  fileSuffixes: string[];
}

/**
 * 一个极简、通用的单文件选择器。
 * A minimal, general-purpose single-file picker.
 * 直接使用 DocumentViewPicker 并通过文件后缀进行过滤。
 * Uses DocumentViewPicker directly and filters by file suffix.
 */
export class FilePicker {
  /**
   * 启动系统UI以选择单个文件。
   * Launch the system UI to select a single file.
   *
   * @param options {SelectOptions} 包含文件后缀的配置对象。 / Configuration object containing the file suffixes.
   * @returns {Promise<string>} 成功时返回所选文件的URI。 / Returns the URI of the selected file on success.
   * @throws {Error} 如果用户取消或发生错误，则抛出异常。 / Throws if the user cancels or an error occurs.
   */
  public static async select(options: SelectOptions): Promise<string> {
    const documentPicker = new picker.DocumentViewPicker();

    // 构建选择器参数，直接使用后缀过滤
    // Build the picker parameters, filtering directly by suffix
    const pickerOptions: picker.DocumentSelectOptions = {
      maxSelectNumber: 1,
      fileSuffixFilters: options.fileSuffixes,
    };

    try {
      const uris = await documentPicker.select(pickerOptions);

      // 验证返回结果
      // Validate the returned result
      if (uris && uris.length > 0) {
        return uris[0]; // 返回单个文件的URI / Return the single file URI
      } else {
        // 用户关闭了选择器但未选择文件
        // The user closed the picker without selecting a file
        throw new Error('No file was selected.');
      }
    } catch (err) {
      const error = err as BusinessError;
      // 错误码 100001 是官方定义的“用户取消操作”
      // Error code 100001 is the officially defined “user cancelled the operation”
      if (error.code === 100001) {
        console.info('[FilePicker] User cancelled the selection.');
        throw new Error('User cancelled selection.');
      } else {
        console.error(`[FilePicker] Selection failed, code: ${error.code}, message: ${error.message}`);
        throw new Error('File selection failed.');
      }
    }
  }
}