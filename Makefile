ARCHS = arm64
TARGET = iphone:clang:latest:15.0
SIGNING = NO
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = cfwh
cfwh_FILES = main.mm
cfwh_CFLAGS = -fobjc-arc
cfwh_LDFLAGS = -framework Foundation -framework UIKit

include $(THEOS)/makefiles/tweak.mk
