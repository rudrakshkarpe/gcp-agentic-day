import requests
from bs4 import BeautifulSoup
import datetime
from dateutil.relativedelta import relativedelta # For date calculations
        

def get_dropdown_options(session, url, dropdown_id):
    """
    Fetches the initial page and extracts options from a specific dropdown.
    Returns a dictionary mapping option text to its value.
    """
    try:
        response = session.get(url, timeout=30)
        response.raise_for_status()
        soup = BeautifulSoup(response.text, 'html.parser')
        
        dropdown = soup.find('select', {'id': dropdown_id})
        if not dropdown:
            print(f"Dropdown with ID '{dropdown_id}' not found.")
            return {}

        options = {}
        for option in dropdown.find_all('option'):
            text = option.text.strip()
            value = option.get('value')
            if text and value:
                options[text] = value
        return options
    except requests.exceptions.RequestException as e:
        print(f"Error fetching dropdown options from {url} for {dropdown_id}: {e}")
        return {}
    except Exception as e:
        print(f"Error parsing dropdown options for {dropdown_id}: {e}")
        return {}

def get_agmarknet_data(session, commodity_id,state_id, commodity_name, state_name, start_dt, end_dt):
    """
    Fetches market data from Agmarknet.gov.in using a POST request to the data endpoint.
    Args:
        session (requests.Session): The session object to maintain cookies.
        commodity_id (str): The numeric ID of the commodity (e.g., "1").
        market_id (str): The numeric ID of the market (e.g., "100").
        date_str (str): Date in DD-MM-YYYY format (e.g., "23-07-2025").
    Returns:
        list: A list of dictionaries, each representing a price record.
    """
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        'X-Requested-With': 'XMLHttpRequest', # Often required for AJAX endpoints
    }
    # The POST endpoint for daily prices on Agmarknet (this is a common pattern)
    AGMARKNET_DATA_BASE_URL = "https://agmarknet.gov.in/SearchCmmMkt.aspx?"
    payload = f"Tx_Commodity={commodity_id}&Tx_State={state_id}&Tx_District=0&Tx_Market=0&DateFrom={start_dt}&DateTo={end_dt}&Fr_Date={start_dt}&To_Date={end_dt}&Tx_Trend=0&Tx_CommodityHead={commodity_name}&Tx_StateHead={state_name}&Tx_DistrictHead=--Select--&Tx_MarketHead=--Select--"
    AGMARKNET_DATA_ENDPOINT = AGMARKNET_DATA_BASE_URL + payload 
    print(f"Fetching Agmarknet data for CommId: {commodity_id}, MktId: {state_id}, Date: {start_dt} to {end_dt}")

    records = []
    try:
        get_response = session.get(AGMARKNET_DATA_ENDPOINT, timeout=30)
        get_response.raise_for_status()
        get_soup = BeautifulSoup(get_response.text, 'html.parser')
        price_table = get_soup.find('table', {'id': 'cphBody_GridPriceData'})
        
        if price_table:
            rows = price_table.find_all('tr')
            if len(rows) > 1: # Skip header row
                # Extract headers for better data mapping
                headers = [th.text.strip() for th in rows[0].find_all('th')]
                
                for row in rows[1:]:
                    cols = row.find_all('td')
                    record = {}
                    # Map columns to headers, adjust indices if needed
                    # This assumes a consistent order and number of columns
                    if len(cols) >= len(headers): # Ensure enough columns
                        for i, header in enumerate(headers):
                            record[header.replace(' ', '_').lower()] = cols[i].text.strip()
                        
                        # Add scraped_at timestamp
                        record["scraped_at"] = datetime.datetime.now().isoformat()
                        records.append(record)
                    else:
                        print(f"Skipping row due to insufficient columns: {row.text.strip()}")
            else:
                print("No data rows found in the table.")
        else:
            print("Price table not found in Agmarknet response. Check selector.")
            # If the response is empty or indicates no data, it might be a valid state
            if "No Record Found" in get_response.text:
                print("Agmarknet reported 'No Record Found' for this query.")

        print(f"Scraped {len(records)} records from Agmarknet.")
        return records

    except requests.exceptions.RequestException as e:
        print(f"HTTP Request to Agmarknet failed: {e}")
        return []
    except Exception as e:
        print(f"Error during Agmarknet scraping: {e}")
        return []

def scrape_agmarknet_trigger(TARGET_COMMODITIES_STATES: dict):
    """
    This tool is called to extract commodity prices for all places specified in user query.

    Args:
        TARGET_COMMODITIES_STATES (dict): A dictionary of commodity , state and district for which prices are required

    Returns:
        dict: A dictionary with the min,max modal prices for each of the commodities.

    Example:
        >>> scrape_agmarknet_trigger(TARGET_COMMODITIES_STATES={
             'Onion': {
                    "state":['Karnataka'],
                    "district": ['Chikmagalur'],
                },
            'Potato': {
                    "state":['Karnataka'],
                    "district": ['Chikmagalur'],
                }
            })
            {
            'Onion_Karnataka': [{'Chikmagalur': {'market_name':'Chikkamagalore', min_price_(rs./kg)': 20.74, 'max_price_(rs./kg)': 22.74, 'modal_price_(rs./kg)': 21.74, 'price_date': '22 Jul 2025'}], 
            'Potato_Karnataka': [{'Chikmagalur: {'market_name':'Chikkamagalore', min_price_(rs./kg)': 20.84, 'max_price_(rs./kg)': 20.84, 'modal_price_(rs./kg)': 20.84, 'price_date': '22 Jul 2025'}]
            }
    """
    print(f"Agmarknet Scraper Cloud Run service invoked {TARGET_COMMODITIES_STATES}.")
    
    # Define the date range for scraping (e.g., last month to today)
    AGMARKNET_REPORT_PAGE_URL = "https://agmarknet.gov.in/PriceAndArrivals/DatewiseCommodityReport.aspx"
    end_date = datetime.date.today()
    start_date = end_date
    final_prices = {}
    
    with requests.Session() as session:
        # Dynamically get commodity and state IDs from the initial page
        commodity_options = get_dropdown_options(session, AGMARKNET_REPORT_PAGE_URL, "ddlCommodity")
        state_options = get_dropdown_options(session, AGMARKNET_REPORT_PAGE_URL, "ddlState")
        if not commodity_options or not state_options:
            return "Failed to retrieve commodity or state options from Agmarknet. Cannot proceed.", 500

        for commodity_name, value in TARGET_COMMODITIES_STATES.items():
            commodity_id = commodity_options.get(commodity_name)
            value["district"] = [dist.lower() for dist in value["district"]]
            if not commodity_id:
                print(f"Warning: Commodity '{commodity_name}' not found in dropdown options. Skipping.")
                continue

            for ix,state_name in enumerate(value["state"]):
                state_id = state_options.get(state_name)
                key = commodity_name + "_" + state_name
                final_prices[key] = []
                if not state_id:
                    print(f"Warning: State '{state_name}' not found in dropdown options. Skipping for {commodity_name}.")
                    continue

                print(f"Processing {commodity_name} in {state_name} from {start_date} to {end_date}")
                scraped_data = get_agmarknet_data(session, commodity_id, state_id, commodity_name ,state_name,start_date, end_date)
                if scraped_data:
                    for rows in scraped_data:
                        if rows["district_name"].lower() in value["district"]:
                            final_prices[key].append({
                                rows["district_name"]:{
                                    "market_name": rows["market_name"],
                                    "max_price_(rs./kg)": int(rows["max_price_(rs./quintal)"])/100 ,
                                    "min_price_(rs./kg)": int(rows["min_price_(rs./quintal)"])/100,
                                    "modal_price_(rs./kg)":  int(rows["modal_price_(rs./quintal)"])/100 ,
                                    "price_date": rows["price_date"],
                                }
                            })
                            #gcs_path = upload_to_gcs(final_prices)
                            # if gcs_path:
                            #     all_uploaded_paths.append(gcs_path)
                    print(final_prices)
                else:
                    print(f"No data scraped for {commodity_name} in {state_name}")
                    continue
        return final_prices

# TARGET_COMMODITIES_STATES = {
#     'Onion': {
#         "state":['Karnataka'],
#         "district": ['Chikmagalur'],
#     },
#     'Potato': {
#         "state":['Karnataka'],
#         "district": ['Chikmagalur'],
#     }
# }

# scrape_agmarknet_trigger(TARGET_COMMODITIES_STATES, "1:days")

