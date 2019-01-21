require "application_system_test_case"

class MefTest < ApplicationSystemTestCase
  setup do
    @mef = mef(:one)
  end

  test "visiting the index" do
    visit mef_url
    assert_selector "h1", text: "Mef"
  end

  test "creating a Mef" do
    visit mef_url
    click_on "New Mef"

    fill_in "Code", with: @mef.code
    fill_in "Libelle", with: @mef.libelle
    fill_in "References", with: @mef.references
    click_on "Create Mef"

    assert_text "Mef was successfully created"
    click_on "Back"
  end

  test "updating a Mef" do
    visit mef_url
    click_on "Edit", match: :first

    fill_in "Code", with: @mef.code
    fill_in "Libelle", with: @mef.libelle
    fill_in "References", with: @mef.references
    click_on "Update Mef"

    assert_text "Mef was successfully updated"
    click_on "Back"
  end

  test "destroying a Mef" do
    visit mef_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Mef was successfully destroyed"
  end
end
