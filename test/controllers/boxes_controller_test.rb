# frozen_string_literal: true

# require "test_helper"

# class BoxesControllerTest < ActionDispatch::IntegrationTest
#   setup do
#     @expertise_box = boxes(:gio_box_expertise) # Example: Expertise Box for Giovanni
#     @education_box = boxes(:gio_box_education) # Example: Education Box for Giovanni
#     @mission_box = boxes(:nat_box_mission)     # Example: Mission Box for Natalie
#     sign_in_as(users(:default_user))           # Mocking sign-in for a default user
#   end

#   # Helper to mock user sign-in
#   def sign_in_as(user)
#     post login_url, params: { session: { email: user.email, password: 'password' } }
#   end

#   test "should get index" do
#     get boxes_url
#     assert_response :success
#   end

#   test "should get new" do
#     get new_box_url
#     assert_response :success
#   end

#   test "should create box" do
#     assert_difference("Box.count") do
#       post boxes_url, params: { box: { profile_id:
# @expertise_box.profile_id, section_id: @expertise_box.section_id, title_en: "New Box", visible: true } }
#     end

#     assert_redirected_to box_url(Box.last)
#   end

#   test "should show box" do
#     get box_url(@expertise_box)
#     assert_response :success
#   end

#   test "should get edit" do
#     get edit_box_url(@expertise_box)
#     assert_response :success
#   end

#   test "should update box" do
#     patch box_url(@expertise_box), params: { box: { title_en: "Updated Expertise Box" } }
#     assert_redirected_to box_url(@expertise_box)
#   end

#   test "should destroy box" do
#     assert_difference("Box.count", -1) do
#       delete box_url(@education_box)
#     end

#     assert_redirected_to boxes_url
#   end

#   test "should show box only if visible" do
#     @mission_box.update(visible: false) # Ensure box is not visible
#     get box_url(@mission_box)
#     assert_response :not_found, "Expected not found response for invisible box"
#   end

#   test "should filter boxes based on audience level" do
#     assert_equal 2, boxes(:nat_box_availability).audience
#     assert boxes(:nat_box_availability).visible, "Availability box should be visible for intranet audience"
#   end
# end
