#!/usr/bin/env python3
# Description: Configure FoxyProxy
# Author: Louay

from webdriver_manager.firefox import GeckoDriverManager
from selenium.webdriver.firefox.options import Options
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.firefox.service import Service as FirefoxService
import subprocess, os, json, glob, time, pyautogui

def first_run():

    subprocess.Popen(['firefox'])
    time.sleep(20)
    subprocess.run(['pkill', '-f', 'firefox'])
    
def get_default_firefox_profile_name(func):
    
    base_profile_path = os.path.expanduser('~/.mozilla/firefox/')

    profile_dirs = glob.glob(os.path.join(base_profile_path, '*.default-esr'))
    if not profile_dirs:
        subprocess.run(["rm", "-rf", "~/.mozilla"])
        func()
        if not profile_dirs:
           raise Exception("No .default-esr profile directory found. Even after retrying!!")
    profile_path = profile_dirs[0]
    return profile_path


def get_foxyproxy_extension_id():

    base_profile_path = os.path.expanduser('~/.mozilla/firefox/')
    profile_dirs = glob.glob(os.path.join(base_profile_path, '*.default-esr'))

    profile_path = profile_dirs[0]
    prefs_js_path = os.path.join(profile_path, 'prefs.js')

    if not os.path.exists(prefs_js_path):
        raise Exception("prefs.js not found!!")

    with open(prefs_js_path, 'r') as file:
        for line in file:
            if 'extensions.webextensions.uuids' in line:
                json_str = line.split('", "', 1)[1].rstrip('");\n')
                json_str = json_str.replace('\\', '').replace('\"', '"')
                uuids = json.loads(json_str)
                return uuids.get('foxyproxy@eric.h.jung')
    raise Exception("Extension ID not found!!")

def import_foxyproxy_config(driver, extension_id, profile_path):

    url = f'moz-extension://{extension_id}/content/options.html'
    driver.get(url)
    time.sleep(2)
    import_button = driver.find_element(By.ID, "file")
    driver.execute_script("arguments[0].click();", import_button)
    time.sleep(2)
    pyautogui.press('enter')
    time.sleep(2)
    save_button = driver.find_element(By.CSS_SELECTOR, "button[data-i18n='saveOptions']")
    save_button.click()
    time.sleep(5)
    
if __name__ == "__main__":

    first_run()
    options = Options()
    options.add_argument("-profile")
    options.add_argument(get_default_firefox_profile_name(first_run))

    driver = webdriver.Firefox(options=options, service=FirefoxService(GeckoDriverManager().install()))

    try:

        import_foxyproxy_config(driver, get_foxyproxy_extension_id(), get_default_firefox_profile_name(first_run))

    finally:

        driver.quit()
