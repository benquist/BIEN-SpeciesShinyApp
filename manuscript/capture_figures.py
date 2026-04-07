from pathlib import Path
import os
from playwright.sync_api import TimeoutError as PlaywrightTimeoutError
from playwright.sync_api import sync_playwright

url = os.getenv("BIEN_APP_URL", "http://127.0.0.1:8787")
fig_dir = Path("figures")
fig_dir.mkdir(parents=True, exist_ok=True)
lock_file = fig_dir / "locked_screenshot_species.txt"

candidates = [
    "Pinus ponderosa",
    "Quercus alba",
    "Acer negundo",
    "Populus tremuloides",
    "Eschscholzia californica",
]


def click_first_available_tab(page, names, timeout=20000):
    for name in names:
        tab = page.get_by_role("tab", name=name)
        if tab.count() > 0:
            tab.first.click(timeout=timeout)
            return name
    raise RuntimeError(f"None of the tab names were found: {names}")


def assert_current_app_layout(page):
    tab_names = [tab.inner_text().strip() for tab in page.get_by_role("tab").all()]
    if "Observations" not in tab_names:
        raise RuntimeError("Current app layout check failed: 'Observations' tab not found.")
    if "Summary Statistics" in tab_names:
        raise RuntimeError(
            "Current app layout check failed: found legacy 'Summary Statistics' tab. "
            "Capture must run against the current app version where summary stats are in Observations."
        )


def query_species(page, species_name):
    click_first_available_tab(page, ["Occurrence", "Occurrence Map"], timeout=20000)
    species = page.locator("#species")
    species.click()
    species.fill(species_name)
    page.get_by_role("button", name="Query BIEN").click()


def wait_for_occurrence_data(page):
    page.wait_for_function(
        """() => {
            const n = document.querySelectorAll('path.leaflet-interactive, .leaflet-marker-icon').length;
            return n > 20;
        }""",
        timeout=180000,
    )


def wait_for_trait_rows(page):
    click_first_available_tab(page, ["Traits"], timeout=30000)
    page.wait_for_timeout(2500)
    page.wait_for_function(
        """() => {
            const rows = Array.from(document.querySelectorAll('#trait_table table tbody tr'));
            if (rows.length === 0) return false;
            if (rows.length === 1 && /No data available/i.test(rows[0].innerText || '')) return false;
            return rows.length >= 2;
        }""",
        timeout=150000,
    )


def species_has_both(page, species_name):
    try:
        query_species(page, species_name)
        wait_for_occurrence_data(page)
        wait_for_trait_rows(page)
        return True
    except PlaywrightTimeoutError:
        return False


def capture_summary_stats(page):
    tab_names = [tab.inner_text().strip() for tab in page.get_by_role("tab").all()]

    if "Summary Statistics" in tab_names:
        page.get_by_role("tab", name="Summary Statistics").click(timeout=30000)
        button = page.get_by_role("button", name="Load BIEN total counts and source mix (slower)")
        if button.count() > 0:
            button.first.click(timeout=30000)
            page.wait_for_timeout(2500)
        try:
            page.wait_for_function(
                """() => {
                    const el = document.querySelector('#query_summary');
                    if (!el) return false;
                    const txt = (el.innerText || '').trim();
                    return txt.length > 40;
                }""",
                timeout=180000,
            )
        except PlaywrightTimeoutError:
            page.wait_for_timeout(1500)
    else:
        click_first_available_tab(page, ["Observations", "Observation Table"], timeout=30000)
        heading = page.get_by_role("heading", name="Summary Statistics")
        if heading.count() > 0:
            heading.first.scroll_into_view_if_needed()
        button = page.get_by_role("button", name="Load BIEN total counts and source mix (slower)")
        if button.count() > 0:
            button.first.click(timeout=30000)
            page.wait_for_timeout(2500)
        try:
            page.wait_for_function(
                """() => {
                    const el = document.querySelector('#query_summary');
                    if (!el) return false;
                    const txt = (el.innerText || '').trim();
                    return txt.length > 40;
                }""",
                timeout=180000,
            )
        except PlaywrightTimeoutError:
            page.wait_for_timeout(1500)

    page.wait_for_timeout(2000)
    query_summary = page.locator("#query_summary")
    if query_summary.count() > 0:
        try:
            query_summary.first.scroll_into_view_if_needed()
            query_summary.first.screenshot(path=str(fig_dir / "fig_summary_stats.png"))
        except PlaywrightTimeoutError:
            page.screenshot(path=str(fig_dir / "fig_summary_stats.png"))
    else:
        page.screenshot(path=str(fig_dir / "fig_summary_stats.png"))


with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page(viewport={"width": 1900, "height": 1200})
    page.goto(url, wait_until="domcontentloaded", timeout=120000)
    page.wait_for_timeout(6000)
    assert_current_app_layout(page)

    locked_species = None
    if lock_file.exists() and lock_file.read_text(encoding="utf-8").strip():
        locked_species = lock_file.read_text(encoding="utf-8").strip()
        if not species_has_both(page, locked_species):
            locked_species = None
            for candidate in candidates:
                if species_has_both(page, candidate):
                    locked_species = candidate
                    lock_file.write_text(locked_species + "\n", encoding="utf-8")
                    break
            if not locked_species:
                browser.close()
                raise RuntimeError("No candidate species produced both occurrence and trait data after locked-species fallback.")
    else:
        for candidate in candidates:
            if species_has_both(page, candidate):
                locked_species = candidate
                lock_file.write_text(locked_species + "\n", encoding="utf-8")
                break
        if not locked_species:
            browser.close()
            raise RuntimeError("No candidate species produced both occurrence and trait data.")

    query_species(page, locked_species)
    wait_for_occurrence_data(page)
    page.wait_for_timeout(2500)
    page.screenshot(path=str(fig_dir / "fig_occurrence_map.png"))

    wait_for_trait_rows(page)
    page.wait_for_timeout(2000)
    page.screenshot(path=str(fig_dir / "fig_trait_data.png"))

    query_species(page, locked_species)
    wait_for_occurrence_data(page)
    capture_summary_stats(page)

    browser.close()

print(f"Saved screenshots for locked species: {locked_species}")
