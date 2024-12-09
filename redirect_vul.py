from flask import Flask, request, redirect

app = Flask(__name__)

@app.route("/redirect")
def insecure_redirect():
    url = request.args.get("url")
    return redirect(url)

if __name__ == "__main__":
    app.run(debug=True)
