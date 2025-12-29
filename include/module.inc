.code64
.intel_syntax noprefix

.extern mutex_guard_lock
.extern virtual_map
.extern free_map
.extern _allocate
.extern _free

.extern print
.extern _strcmp
.extern _strlen
.extern _strncpy
.extern atomic_load
.extern atomic_store