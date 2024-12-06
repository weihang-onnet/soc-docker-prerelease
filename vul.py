import hashlib

def store_password(password):
    # Vulnerable: MD5 is considered weak
    hash_object = hashlib.md5(password.encode())
    print(f"Storing password hash: {hash_object.hexdigest()}")

store_password(input("Enter a password: "))
