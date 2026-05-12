#!/usr/bin/env bash
set -euo pipefail

mode="${1:-sim}"

case "${mode}" in
  build)
    make build
    ;;
  sim)
    test_name="${2:-${TEST:-uart_sanity_test}}"
    make sim TEST="${test_name}" VERBOSITY="${VERBOSITY:-UVM_MEDIUM}"
    ;;
  regress)
    if [[ $# -ge 2 ]]; then
      export TESTS="$2"
    fi
    make regress VERBOSITY="${VERBOSITY:-UVM_MEDIUM}"
    ;;
  sanity-ci)
    make sanity-ci
    ;;
  help|-h|--help)
    make help
    echo ""
    echo "run.sh examples:"
    echo "  ./run.sh build"
    echo "  ./run.sh sim uart_sanity_test"
    echo "  ./run.sh regress"
    echo "  ./run.sh regress \"uart_sanity_test uart_rand_test\""
    echo "  ./run.sh sanity-ci"
    ;;
  *)
    echo "unsupported mode: ${mode}"
    echo "use: ./run.sh [build|sim|regress|sanity-ci|help] [test-or-test-list]"
    exit 1
    ;;
esac
