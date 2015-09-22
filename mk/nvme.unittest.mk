#
#  BSD LICENSE
#
#  Copyright(c) 2010-2015 Intel Corporation. All rights reserved.
#  All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions
#  are met:
#
#    * Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#    * Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimer in
#      the documentation and/or other materials provided with the
#      distribution.
#    * Neither the name of Intel Corporation nor the names of its
#      contributors may be used to endorse or promote products derived
#      from this software without specific prior written permission.
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
#  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
#  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
#  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
#  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
#  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

SPDK_ROOT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/..
NVME_DIR := $(SPDK_ROOT_DIR)/lib/nvme

include $(SPDK_ROOT_DIR)/CONFIG

C_OPT ?= -O2 -fno-omit-frame-pointer
Q ?= @
S ?= $(notdir $(CURDIR))

C_SRCS = $(TEST_FILE) $(OTHER_FILES)

OBJS = $(C_SRCS:.c=.o)

CFLAGS += $(C_OPT) -I$(SPDK_ROOT_DIR)/lib -I$(SPDK_ROOT_DIR)/include -include $(SPDK_ROOT_DIR)/test/lib/nvme/unit/nvme_impl.h

LIBS += -lcunit -lpthread

UT_APP = $(TEST_FILE:.c=)

all: $(UT_APP)

$(UT_APP) : $(OBJS)
	@echo "  LINK $@"
	$(Q)$(CC) $(CFLAGS) -o $@ $(OBJS) $(LIBS)

clean:
	$(Q)rm -f $(UT_APP) $(OBJS) *.d

%.o: $(NVME_DIR)/%.c
	@echo "  CC $@"
	$(Q)$(CC) $(CFLAGS) -c $< -o $@
	$(Q)$(CC) -MM $(CFLAGS) $(NVME_DIR)/$*.c > $*.d
	@mv -f $*.d $*.d.tmp
	@sed -e 's|.*:|$*.o:|' < $*.d.tmp > $*.d
	@sed -e 's/.*://' -e 's/\\$$//' < $*.d.tmp | fmt -1 | \
		sed -e 's/^ *//' -e 's/$$/:/' >> $*.d
	@rm -f $*.d.tmp
