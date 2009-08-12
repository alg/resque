require File.dirname(__FILE__) + '/test_helper'

context "Resque" do
  setup do
    @queue = Resque.new('localhost:6379')
    @queue.redis.flush_all

    @queue.push(:people, 'chris')
    @queue.push(:people, 'bob')
    @queue.push(:people, 'mark')
  end

  test "can put jobs on a queue" do
    assert @queue.enqueue(:jobs, 'SomeJob', 20, '/tmp')
  end

  test "can grab jobs off a queue" do
    @queue.enqueue(:jobs, 'some-job', 20, '/tmp')

    job = @queue.reserve(:jobs)

    assert_kind_of Resque::Job, job
    assert_kind_of SomeJob, job.object
    assert_equal 20, job.object.repo_id
    assert_equal '/tmp', job.object.path
  end

  test "can put items on a queue" do
    assert @queue.push(:people, 'jon')
  end

  test "can pull items off a queue" do
    assert_equal 'chris', @queue.pop(:people)
    assert_equal 'bob', @queue.pop(:people)
    assert_equal 'mark', @queue.pop(:people)
    assert_equal nil, @queue.pop(:people)
  end

  test "knows how big a queue is" do
    assert_equal 3, @queue.size(:people)

    assert_equal 'chris', @queue.pop(:people)
    assert_equal 2, @queue.size(:people)

    assert_equal 'bob', @queue.pop(:people)
    assert_equal 'mark', @queue.pop(:people)
    assert_equal 0, @queue.size(:people)
  end

  test "can peek at a queue" do
    assert_equal 'chris', @queue.peek(:people)
    assert_equal 3, @queue.size(:people)
  end

  test "can peek multiple items on a queue" do
    assert_equal 'bob', @queue.peek(:people, 1, 1)

    assert_equal ['bob', 'mark'], @queue.peek(:people, 1, 2)
    assert_equal ['chris', 'bob'], @queue.peek(:people, 0, 2)
    assert_equal ['chris', 'bob', 'mark'], @queue.peek(:people, 0, 3)
    assert_equal 'mark', @queue.peek(:people, 2, 1)
    assert_equal nil, @queue.peek(:people, 3)
    assert_equal [], @queue.peek(:people, 3, 2)
  end
end