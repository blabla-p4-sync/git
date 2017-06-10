#!/bin/sh

test_description="Test core.fsmonitor"

. ./perf-lib.sh

test_perf_large_repo
test_checkout_worktree

test_expect_success 'setup' '
	# Maybe set untrackedCache & splitIndex depending on the
	# environment, defaulting to false.
	if test -n "$GIT_PERF_7519_UNTRACKED_CACHE"
	then
		git config core.untrackedCache true
	else
		git config core.untrackedCache false
	fi &&
	if test -n "$GIT_PERF_7519_SPLIT_INDEX"
	then
		git config core.splitIndex true
	else
		git config core.splitIndex false
	fi &&

	# Relies on core.fsmonitor not being merged into master. Needs
	# better per-test ways to disable it if it gets merged.
	git config core.fsmonitor true &&

	# Hook scaffolding
	mkdir .git/hooks &&
	cp ../../../templates/hooks--query-fsmonitor.sample .git/hooks/query-fsmonitor &&

	# Setup watchman & ensure it is actually watching
	watchman watch-del "$PWD" >/dev/null 2>&1 &&
	watchman watch "$PWD" >/dev/null 2>&1 &&
	watchman watch-list | grep -q -F "$PWD"
'

# Setting:
#
#    GIT_PERF_REPEAT_COUNT=1 GIT_PERF_MAKE_COMMAND='sudo sync && echo 3 | sudo tee /proc/sys/vm/drop_caches && make -j8'
#
# Can be used as a hack to performance test 'git status' on a cold fs
# cache with an existing watchman watching the directory, which should
# be blindingly fast, compared to amazingly slow without watchman.
test_perf 'status (first)'       'git status'


# The same git-status once the fs cache has been warmed, if using the
# GIT_PERF_MAKE_COMMAND above. Otherwise the same as above.
test_perf 'status (subsequent)'  'git status'

# Let's see if -uno & -uall make any difference
test_perf 'status -uno'          'git status -uno'
test_perf 'status -uall'         'git status -uall'

test_done
