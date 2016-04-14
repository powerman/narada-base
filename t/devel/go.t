#!/bin/sh
exec 3>&1 1>&2 2>&3 3>&-
{
        # Print progress to STDOUT:
        # - it will be prefixed by "# "
        # - it can be output either to real STDOUT (shown only by
        #   prove -v) or real STDERR (shown always)
        # Print TAP to STDERR:
        # - it will be output to real STDOUT as is
        echo 1..$(find t/ -name '*.cover.test' -o -name '*.race.test' | wc -l) >&2
        rm -f tmp/*.cover.test.out
        for t in $(find -name '*.cover.test'); do
                cover=$(echo $t | sed 's/^.\///' | tr / _)
                extra=$($t -h 2>&1 | grep '^\s*-check.v$')
                echo
                echo $t
                $t $extra -test.v -test.coverprofile=tmp/${cover}.out 2>&1 && echo ok >&2 || echo not ok >&2
        done
        for t in $(find t/ -name '*.race.test'); do
                extra=$($t -h 2>&1 | grep '^\s*-check.v$')
                echo
                echo $t
                $t $extra -test.v 2>&1 && echo ok >&2 || echo not ok >&2
        done
        cat tmp/*.cover.test.out | perl -ne 'print if !/^mode:/ || $.==1' > tmp/cover.out
        echo "To view coverage report: go tool cover -html=_live/tmp/cover.out"
} | sed -u 's/^/# /' # >&2      # use >&2 to show progress only by prove -v
