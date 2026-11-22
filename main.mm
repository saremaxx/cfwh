#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <mach-o/dyld.h>
#include <string.h>
#include <mach/mach.h>
#include <libkern/OSCacheControl.h>

// RVA метода IsWallhacked из PlayerCulling (из dump.cs)
#define RVA_PLAYER_CULLING_WALLHACK 0x162DFB8

// Инструкции ARM64: mov w0, #1 (возврат true); ret (выход)
static const uint32_t patch_bytes[] = { 0x20008052, 0xC0035FD6 }; 

__attribute__((constructor))
static void init() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        uintptr_t base = 0;
        for (int i = 0; i < _dyld_image_count(); i++) {
            const char *name = _dyld_get_image_name(i);
            if (strstr(name, "UnityFramework")) {
                base = _dyld_get_image_vmaddr_slide(i);
                break;
            }
        }
        if (base != 0) {
            uintptr_t target = base + RVA_PLAYER_CULLING_WALLHACK;
            vm_address_t page = target & ~(PAGE_SIZE - 1);
            
            vm_protect(mach_task_self(), page, PAGE_SIZE, false, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_EXECUTE);
            memcpy((void *)target, patch_bytes, sizeof(patch_bytes));
            sys_icache_invalidate((void *)target, sizeof(patch_bytes));
            vm_protect(mach_task_self(), page, PAGE_SIZE, false, VM_PROT_READ | VM_PROT_EXECUTE);
        }
    });
}
