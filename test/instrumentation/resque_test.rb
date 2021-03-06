# Copyright (c) 2015 AppNeta, Inc.
# All rights reserved.

require 'minitest_helper'

describe "Resque" do
  before do
    clear_all_traces

    # These are standard entry/exit KVs that are passed up with all moped operations
    @entry_kvs = {
      'Layer' => 'resque',
      'Label' => 'entry' }

    @exit_kvs = { 'Layer' => 'resque', 'Label' => 'exit' }
  end

  it 'Stock Resque should be loaded, defined and ready' do
    defined?(::Resque).wont_match nil
    defined?(::Resque::Worker).wont_match nil
    defined?(::Resque::Job).wont_match nil
  end

  it 'Resque should have traceview methods defined' do
    [ :enqueue, :enqueue_to, :dequeue ].each do |m|
      ::Resque.method_defined?("#{m}_with_traceview").must_equal true
    end

    ::Resque::Worker.method_defined?("perform_with_traceview").must_equal true
    ::Resque::Job.method_defined?("fail_with_traceview").must_equal true
  end

  it "should trace enqueue" do
    skip
    TraceView::API.start_trace('resque-client_test', '', {}) do
      Resque.enqueue(TraceViewResqueJob, { :generate => :activerecord, :delay => rand(5..30).to_f })
      Resque.enqueue(TraceViewResqueJobThatFails)
      Resque.dequeue(TraceViewResqueJob, { :generate => :moped })
    end

    traces = get_all_traces

    traces.count.must_equal 4
    validate_outer_layers(traces, 'resque-client_test')

    validate_event_keys(traces[1], @entry_kvs)
    validate_event_keys(traces[2], @exit_kvs)
  end

  it "should trace dequeue" do
    skip
    TraceView::API.start_trace('resque-client_test', '', {}) do
      Resque.dequeue(TraceViewResqueJob, { :generate => :moped })
    end

    traces = get_all_traces

    traces.count.must_equal 4
    validate_outer_layers(traces, 'resque-client_test')

    validate_event_keys(traces[1], @entry_kvs)
    validate_event_keys(traces[2], @exit_kvs)
  end
end

