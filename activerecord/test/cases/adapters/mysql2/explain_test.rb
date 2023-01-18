# frozen_string_literal: true

require "cases/helper"
require "models/author"
require "models/post"

class Mysql2ExplainTest < ActiveRecord::Mysql2TestCase
  fixtures :authors, :author_addresses

  def test_explain_for_one_query
    explain = Author.where(id: 1).explain
    assert_match %(EXPLAIN SELECT `authors`.* FROM `authors` WHERE `authors`.`id` = 1), explain
    assert_match %r(authors |.* const), explain
  end

  def test_explain_with_eager_loading
    explain = Author.where(id: 1).includes(:posts).explain
    assert_match %(EXPLAIN SELECT `authors`.* FROM `authors` WHERE `authors`.`id` = 1), explain
    assert_match %r(authors |.* const), explain
    assert_match %(EXPLAIN SELECT `posts`.* FROM `posts` WHERE `posts`.`author_id` = 1), explain
    assert_match %r(posts |.* ALL), explain
  end

  def test_explain_with_options_as_symbol
    explain = Author.where(id: 1).explain(:analyze)
    assert_match %(EXPLAIN ANALYZE SELECT `authors`.* FROM `authors` WHERE `authors`.`id` = 1), explain
    assert_match %(actual time=), explain
  end

  def test_explain_with_options_as_strings
    explain = Author.where(id: 1).explain("ANALYZE")
    assert_match %(EXPLAIN ANALYZE SELECT `authors`.* FROM `authors` WHERE `authors`.`id` = 1), explain
    assert_match %(actual time=), explain
  end

  def test_explain_options_with_eager_loading
    explain = Author.where(id: 1).includes(:posts).explain(:analyze)
    assert_match %(EXPLAIN ANALYZE SELECT `authors`.* FROM `authors` WHERE `authors`.`id` = 1), explain
    assert_match %(EXPLAIN ANALYZE SELECT `posts`.* FROM `posts` WHERE `posts`.`author_id` = 1), explain
    assert_match %(actual time=), explain
  end
end
