<?php

namespace App\Domain\Messaging\Controllers;

use App\Domain\Messaging\Models\Message;
use App\Domain\Messaging\Requests\StoreMessageRequest;
use App\Domain\Messaging\Resources\MessageResource;
use App\Domain\Orders\Models\Order;
use Illuminate\Support\Facades\Gate;

class MessageController
{
    public function index(Order $order)
    {
        Gate::authorize('view', $order);

        $messages = Message::query()
            ->where('order_id', $order->id)
            ->orderBy('id')
            ->paginate(50);

        return MessageResource::collection($messages);
    }

    public function store(StoreMessageRequest $request, Order $order)
    {
        Gate::authorize('view', $order);

        $user = $request->user();
        $isBuyer = (int) $order->buyer_user_id === (int) $user->id;
        $isRider = (int) ($order->dispatchJob?->assigned_rider_user_id ?? 0) === (int) $user->id;

        if (! $isBuyer && ! $isRider) {
            return response()->json(['message' => 'Messaging is only allowed between buyer and rider.'], 403);
        }

        $message = Message::create([
            'order_id' => $order->id,
            'sender_user_id' => $user->id,
            'message_text' => (string) $request->validated()['message_text'],
        ]);

        return new MessageResource($message);
    }
}
