
import { vibrator } from '@kit.SensorServiceKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { resourceManager } from '@kit.LocalizationKit';

export class NotificationKitUtils {
  startNotification(uiContext:UIContext) {
    // Obtain the file descriptor of the vibration configuration file.
    let rawFd: resourceManager.RawFileDescriptor | undefined = uiContext.getHostContext()?.resourceManager.getRawFdSync('xxx.json');
    if (rawFd !== undefined) {
      // Start vibration.
      try {
        vibrator.startVibration({
          type: 'file',
          hapticFd: { fd: rawFd.fd, offset: rawFd.offset, length: rawFd.length }
        }, {
          id: 0,
          usage: 'alarm' // The switch control is subject to the selected type.
        }, (error: BusinessError) => {
          if (error) {
            console.error(`Failed to start vibration. Code: ${error.code}, message: ${error.message}`);
            return;
          }
          console.info('Succeed in starting vibration');
        });
      } catch (err) {
        let e: BusinessError = err as BusinessError;
        console.error(`An unexpected error occurred. Code: ${e.code}, message: ${e.message}`);
      }
    }
    // Close the file descriptor of the vibration configuration file.
    uiContext.getHostContext()?.resourceManager.closeRawFdSync('xxx.json');
  }
}