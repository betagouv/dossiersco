require "application_system_test_case"

class OptionsPedagogiquesTest < ApplicationSystemTestCase
  setup do
    @option_pedagogique = options_pedagogiques(:one)
  end

  test "visiting the index" do
    visit options_pedagogiques_url
    assert_selector "h1", text: "Options Pedagogiques"
  end

  test "creating a Option pedagogique" do
    visit options_pedagogiques_url
    click_on "New Option Pedagogique"

    click_on "Create Option pedagogique"

    assert_text "Option pedagogique was successfully created"
    click_on "Back"
  end

  test "updating a Option pedagogique" do
    visit options_pedagogiques_url
    click_on "Edit", match: :first

    click_on "Update Option pedagogique"

    assert_text "Option pedagogique was successfully updated"
    click_on "Back"
  end

  test "destroying a Option pedagogique" do
    visit options_pedagogiques_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Option pedagogique was successfully destroyed"
  end
end
