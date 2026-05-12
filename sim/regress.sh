#!/usr/bin/env bash
set -euo pipefail

mkdir -p logs

summary_file="logs/regression_summary.log"
detail_file="logs/.regression_fail_detail.tmp"
rm -f "${summary_file}" "${detail_file}"
touch "${detail_file}"

default_tests=(
  "uart_sanity_test"
  "uart_rand_test"
  "uart_neg_err_inject_test"
)

if [[ -n "${TESTS:-}" ]]; then
  # shellcheck disable=SC2206
  test_list=(${TESTS})
else
  test_list=("${default_tests[@]}")
fi

declare -A ignore_pattern_map
ignore_pattern_map["uart_neg_err_inject_test"]="EXP_ERR_INJECT|expected error suppressed"

total_count=${#test_list[@]}
pass_count=0
fail_count=0

echo "running regression with ${total_count} cases..."

for test_name in "${test_list[@]}"; do
  log_file="logs/${test_name}.log"
  ignore_pattern="${ignore_pattern_map[${test_name}]:-}"

  echo "  -> ${test_name}"
  set +e
  ./simv +UVM_TESTNAME="${test_name}" +UVM_VERBOSITY="${VERBOSITY:-UVM_MEDIUM}" \
    -l "${log_file}" >/dev/null 2>&1
  run_rc=$?
  set -e

  error_lines="$(
    awk '/UVM_ERROR|UVM_FATAL|Error:/{print}' "${log_file}" \
    | awk '$0 !~ /UVM_ERROR[[:space:]]*:[[:space:]]*0/ &&
           $0 !~ /UVM_FATAL[[:space:]]*:[[:space:]]*0/'
  )"

  if [[ -n "${ignore_pattern}" ]]; then
    error_lines="$(printf "%s\n" "${error_lines}" \
      | awk -v pat="${ignore_pattern}" '$0 !~ pat')"
  fi

  if [[ ${run_rc} -eq 0 && -z "${error_lines}" ]]; then
    pass_count=$((pass_count + 1))
    echo "PASS ${test_name}"
  else
    fail_count=$((fail_count + 1))
    echo "FAIL ${test_name}"
    {
      echo "----------------------------------------"
      echo "FAILED CASE: ${test_name}"
      echo "exit_code: ${run_rc}"
      echo "log: ${log_file}"
      echo "error summary:"
      if [[ -n "${error_lines}" ]]; then
        printf "%s\n" "${error_lines}" | head -n 12
      else
        tail -n 20 "${log_file}"
      fi
      echo ""
    } >> "${detail_file}"
  fi
done

pass_rate="$(awk -v p="${pass_count}" -v t="${total_count}" \
  'BEGIN{if(t==0){printf "0.0"}else{printf "%.1f",(p*100.0)/t}}')"

{
  echo "================ Regression Summary ================"
  echo "total cases : ${total_count}"
  echo "pass cases  : ${pass_count}"
  echo "fail cases  : ${fail_count}"
  echo "pass rate   : ${pass_count}/${total_count} (${pass_rate}%)"
  echo ""
  if [[ ${fail_count} -gt 0 ]]; then
    cat "${detail_file}"
  else
    echo "all cases passed."
  fi
} > "${summary_file}"

rm -f "${detail_file}"
echo "summary generated: ${summary_file}"
