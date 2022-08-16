#!/usr/bin/env ruby
# frozen_string_literal: true

kubeconfig_path = ARGV[0]
namespace = ARGV[1]
expected_containers = ARGV[2]
expected_pods = ARGV[3]

if expected_containers.nil?
  expected_containers = "1/1"
end
if expected_pods.nil?
  expected_pods = "11"
end

def timeout_check(waiting,wait_timeout,check_name)
  # exit if timed out
  if waiting < wait_timeout
    puts "#{check_name} are up after #{waiting} seconds."
  else
    abort "#{check_name} failed to come up in #{wait_timeout} seconds."
  end
end

# test node status
waiting = 0
wait_timeout = 900
kube_cmd = "kubectl --kubeconfig #{kubeconfig_path} get nodes --all-namespaces"
kube_status = `#{kube_cmd}`

# Test nodes for "No resources found." error
while kube_status.empty? && waiting < wait_timeout
  puts kube_cmd
  puts kube_status
  puts "Waiting #{waiting} seconds for nodes to come up..."
  sleep 30
  waiting += 30
  kube_status = `#{kube_cmd}`
end
puts kube_cmd
puts kube_status
timeout_check(waiting,wait_timeout,"Nodes")

# Wait for all pods to come up
kube_cmd = "kubectl --kubeconfig #{kubeconfig_path} get pods -n #{namespace}"
kube_status = `#{kube_cmd}`
pods_up = kube_status.scan(/(?=#{expected_containers})/).count
while (kube_status.empty? || pods_up < expected_pods.to_i) && waiting < wait_timeout
  puts kube_cmd
  puts kube_status
  puts "#{pods_up} pods are up. Expecting at least #{expected_pods}."
  puts "Waiting #{waiting} seconds for pods to come up..."
  sleep 30
  waiting += 30
  kube_status = `#{kube_cmd}`
  pods_up = kube_status.scan(/(?=#{expected_containers})/).count
end
puts kube_cmd
puts kube_status
timeout_check(waiting,wait_timeout,"Pods")