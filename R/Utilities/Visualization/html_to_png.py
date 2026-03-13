from selenium import webdriver
driver = webdriver.Chrome()
driver.set_window_size(3000, 5000)
driver.get("file:///Users/jdp2019/Library/CloudStorage/OneDrive-Emory/Research/Manuscripts and Projects/Grady/Penetrating Kidney Injuries/PKI EAST/CHM_JDP_PKI_2025/PKI-2025/Outputs/preview.html")
driver.save_screenshot("output_nolabels.png")
driver.quit()